<?php

namespace App;

use GuzzleHttp\Client;

class Gateway
{
    private Client $client;

    public function __construct()
    {
        $this->client = new Client([
            'http_errors' => false,
            'timeout' => 20.0, // Увеличили таймаут для медленного Docker
            'connect_timeout' => 5.0
        ]);
    }

    public function handle(): void
    {
        $method = $_SERVER['REQUEST_METHOD'];
        $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        
        $targetBaseUrl = $this->resolveDestination($path);
        $targetUrl = $targetBaseUrl . $_SERVER['REQUEST_URI'];

        try {
            $options = [
                'headers' => $this->getClientHeaders(),
                'body' => file_get_contents('php://input')
            ];
            $response = $this->client->request($method, $targetUrl, $options);
            
            http_response_code($response->getStatusCode());
            foreach ($response->getHeaders() as $name => $values) {
                if (!in_array(strtolower($name), ['transfer-encoding', 'connection'])) {
                    foreach ($values as $value) header("$name: $value", false);
                }
            }
            echo $response->getBody();
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage(), 'url' => $targetUrl]);
        }
    }

    private function resolveDestination(string $path): string
    {
        // 1. События отправляем на events-service
        if (str_starts_with($path, '/api/events')) {
            return 'http://events-service:8082';
        }

        // 2. Фильмы (миграция)
        if (str_starts_with($path, '/api/movies') && getenv('GRADUAL_MIGRATION') === 'true') {
            return 'http://movies-service:8081';
        }

        // 3. Остальное — монолит
        return 'http://monolith:8080';
    }

    private function getClientHeaders(): array
    {
        $headers = [];
        foreach ($_SERVER as $key => $value) {
            if (str_starts_with($key, 'HTTP_')) {
                $name = str_replace('_', '-', strtolower(substr($key, 5)));
                if ($name !== 'host') $headers[$name] = $value;
            }
        }
        return $headers;
    }
}