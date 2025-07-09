#!/bin/bash

# Script de despliegue para mantener el servidor siempre activo
# Incluye configuración de servicio systemd y monitoreo

echo "🚀 Configurando servidor persistente para luisenriquemata.com"

# Verificar permisos de root para systemd
if [ "$EUID" -eq 0 ]; then
    USE_SYSTEMD=true
    echo "✅ Permisos de root detectados - usando systemd"
else
    USE_SYSTEMD=false
    echo "⚠️  Sin permisos de root - usando método alternativo"
fi

# Función para configurar systemd (requiere root)
setup_systemd() {
    echo "📋 Configurando servicio systemd..."
    
    # Copiar archivo de servicio
    cp luisenriquemata.service /etc/systemd/system/
    
    # Recargar systemd
    systemctl daemon-reload
    
    # Habilitar servicio para inicio automático
    systemctl enable luisenriquemata
    
    # Iniciar servicio
    systemctl start luisenriquemata
    
    # Verificar estado
    systemctl status luisenriquemata
    
    echo "✅ Servicio systemd configurado"
    echo "🔧 Comandos útiles:"
    echo "  - Ver estado: systemctl status luisenriquemata"
    echo "  - Ver logs: journalctl -u luisenriquemata -f"
    echo "  - Reiniciar: systemctl restart luisenriquemata"
    echo "  - Detener: systemctl stop luisenriquemata"
}

# Función para configurar como proceso en background
setup_background_process() {
    echo "📋 Configurando proceso en background..."
    
    # Crear script de inicio en background
    cat > run_background.sh << 'EOF'
#!/bin/bash
cd /workspaces/luisenriquemata.com
nohup ./start_server.sh 8000 > server.log 2>&1 &
echo $! > server.pid
echo "✅ Servidor iniciado en background (PID: $(cat server.pid))"
EOF
    
    chmod +x run_background.sh
    
    # Crear script de parada
    cat > stop_server.sh << 'EOF'
#!/bin/bash
if [ -f server.pid ]; then
    PID=$(cat server.pid)
    if kill -0 $PID 2>/dev/null; then
        echo "🛑 Deteniendo servidor (PID: $PID)..."
        kill $PID
        rm server.pid
        echo "✅ Servidor detenido"
    else
        echo "⚠️  Proceso no encontrado"
        rm server.pid
    fi
else
    echo "⚠️  No se encontró archivo PID"
fi
EOF
    
    chmod +x stop_server.sh
    
    echo "✅ Scripts de background configurados"
    echo "🔧 Comandos útiles:"
    echo "  - Iniciar: ./run_background.sh"
    echo "  - Detener: ./stop_server.sh"
    echo "  - Ver logs: tail -f server.log"
}

# Función para configurar crontab para auto-inicio
setup_crontab() {
    echo "📋 Configurando crontab para auto-inicio..."
    
    # Crear script de verificación
    cat > check_server.sh << 'EOF'
#!/bin/bash
cd /workspaces/luisenriquemata.com

# Verificar si el servidor está corriendo
if ! curl -s http://localhost:8000/health >/dev/null 2>&1; then
    echo "$(date): Servidor no responde, reiniciando..." >> cron.log
    ./run_background.sh >> cron.log 2>&1
else
    echo "$(date): Servidor funcionando correctamente" >> cron.log
fi
EOF
    
    chmod +x check_server.sh
    
    # Agregar entrada al crontab (verificar cada 5 minutos)
    (crontab -l 2>/dev/null; echo "*/5 * * * * /workspaces/luisenriquemata.com/check_server.sh") | crontab -
    
    echo "✅ Crontab configurado para verificar servidor cada 5 minutos"
}

# Función principal
main() {
    # Instalar dependencias Python
    echo "📦 Instalando dependencias..."
    pip install -r requirements.txt
    
    if [ "$USE_SYSTEMD" = true ]; then
        setup_systemd
    else
        setup_background_process
        setup_crontab
    fi
    
    echo ""
    echo "🎉 ¡Configuración completada!"
    echo ""
    echo "🌐 Tu servidor estará disponible en:"
    echo "  - http://localhost:8000"
    echo "  - http://0.0.0.0:8000"
    echo ""
    echo "📊 Endpoints de monitoreo:"
    echo "  - Health check: http://localhost:8000/health"
    echo "  - Estado del sistema: http://localhost:8000/api/status"
    echo "  - Ping: http://localhost:8000/api/ping"
    echo ""
    echo "📁 Páginas disponibles:"
    echo "  - Página principal: http://localhost:8000/"
    echo "  - Sobre nosotros: http://localhost:8000/about"
    echo "  - Archivos estáticos: http://localhost:8000/static/"
}

# Ejecutar configuración
main "$@"
