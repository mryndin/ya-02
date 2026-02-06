@echo off
SET NAMESPACE=cinemaabyss

echo [1/3] Searching for Fortio pod...
for /f "tokens=1" %%i in ('kubectl get pod -n %NAMESPACE% ^| findstr fortio') do set FORTIO_POD=%%i

if "%FORTIO_POD%"=="" (
    echo ERROR: Fortio pod not found. Check if it is deployed in %NAMESPACE%.
    pause
    exit /b
)

echo Found Pod: %FORTIO_POD%
echo.
echo [2/3] Starting Load Test (50 connections, 500 requests)...
echo Target: http://movies-service:8081/api/movies
echo.

kubectl exec -n %NAMESPACE% %FORTIO_POD% -c fortio -- fortio load -c 50 -qps 0 -n 500 -loglevel Warning http://movies-service:8081/api/movies

echo.
echo [3/3] Checking Circuit Breaker statistics (pending_overflow)...
kubectl exec -n %NAMESPACE% %FORTIO_POD% -c istio-proxy -- pilot-agent request GET stats | findstr movies-service | findstr pending_overflow

echo.
echo Test completed. Look for Code 503 in the output above.
pause