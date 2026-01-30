FROM php:8.2-alpine

# Устанавливаем Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Копируем файлы composer
COPY composer.json ./

# Устанавливаем зависимости
RUN composer install --no-dev --optimize-autoloader

# Копируем исходный код
COPY . .

# Открываем порт
EXPOSE 8000

# Запускаем встроенный PHP сервер
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]