#!/bin/bash

# Script de inicio del servidor con auto-recuperación
# Para mantener el servidor siempre activo

SERVER_PORT=${1:-8000}
SERVER_HOST=${2:-"0.0.0.0"}
MAX_RETRIES=5
RETRY_DELAY=10

echo "🚀 Iniciando servidor Luis Enrique Mata Landing..."
echo "📍 Puerto: $SERVER_PORT"
echo "📍 Host: $SERVER_HOST"

# Función para verificar si el puerto está libre
check_port() {
    if lsof -Pi :$SERVER_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "⚠️  Puerto $SERVER_PORT ya está en uso"
        echo "Terminando proceso existente..."
        pkill -f "python.*main.py" || true
        sleep 5
    fi
}

# Función para instalar dependencias
install_dependencies() {
    echo "📦 Instalando dependencias..."
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    else
        echo "❌ No se encontró requirements.txt"
        exit 1
    fi
}

# Función para iniciar el servidor
start_server() {
    echo "🌐 Iniciando servidor en http://$SERVER_HOST:$SERVER_PORT"
    python main.py --port $SERVER_PORT --host $SERVER_HOST
}

# Función de monitoreo y auto-recuperación
monitor_and_restart() {
    local retries=0
    
    while [ $retries -lt $MAX_RETRIES ]; do
        echo "🔄 Intento $((retries + 1)) de $MAX_RETRIES"
        
        # Verificar y liberar puerto si es necesario
        check_port
        
        # Iniciar servidor
        start_server &
        SERVER_PID=$!
        
        # Esperar un momento para que el servidor inicie
        sleep 5
        
        # Verificar si el servidor está corriendo
        if kill -0 $SERVER_PID 2>/dev/null; then
            echo "✅ Servidor iniciado correctamente (PID: $SERVER_PID)"
            
            # Monitorear el servidor
            while kill -0 $SERVER_PID 2>/dev/null; do
                sleep 30
                # Verificar health check
                if ! curl -s http://localhost:$SERVER_PORT/health >/dev/null 2>&1; then
                    echo "❌ Health check falló, reiniciando servidor..."
                    kill $SERVER_PID 2>/dev/null || true
                    break
                fi
            done
            
            echo "🛑 Servidor detenido, intentando reiniciar..."
        else
            echo "❌ Error al iniciar servidor"
        fi
        
        retries=$((retries + 1))
        
        if [ $retries -lt $MAX_RETRIES ]; then
            echo "⏳ Esperando $RETRY_DELAY segundos antes del siguiente intento..."
            sleep $RETRY_DELAY
        fi
    done
    
    echo "💥 Máximo número de reintentos alcanzado. Deteniendo script."
    exit 1
}

# Script principal
main() {
    # Verificar si Python está instalado
    if ! command -v python &> /dev/null; then
        echo "❌ Python no está instalado"
        exit 1
    fi
    
    # Verificar si pip está instalado
    if ! command -v pip &> /dev/null; then
        echo "❌ pip no está instalado"
        exit 1
    fi
    
    # Instalar dependencias
    install_dependencies
    
    # Configurar trap para manejar señales de interrupción
    trap 'echo "🛑 Deteniendo servidor..."; kill $SERVER_PID 2>/dev/null || true; exit 0' INT TERM
    
    # Iniciar monitoreo y auto-recuperación
    monitor_and_restart
}

# Ejecutar script principal
main "$@"
