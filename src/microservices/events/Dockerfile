# Используем официальный образ Go как билд-платформу
FROM golang:1.21-alpine AS builder

# Устанавливаем git и build-base (нужны для некоторых зависимостей Go)
RUN apk add --no-cache git build-base

WORKDIR /app

# Копируем только файлы модулей для кэширования слоев
COPY go.mod ./
# Если файла go.sum еще нет, пропустим его копирование
COPY go.sum* ./

# Скачиваем зависимости
RUN go mod download

# Копируем код и собираем
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o events-app main.go

# Финальный легкий образ
FROM alpine:latest
RUN apk add --no-cache ca-certificates
WORKDIR /root/
COPY --from=builder /app/events-app .

# Пробрасываем порт
EXPOSE 8082

CMD ["./events-app"]