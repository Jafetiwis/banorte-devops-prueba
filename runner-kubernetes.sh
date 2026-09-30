# ==============================================================================
# Script: runner-kubernetes.sh
# Descripción: Simulación de pipeline CI/CD estilo GitLabCI usando Kubernetes,
#              aplicación de manifiestos, pruebas HTTP y validación RSH/Exec.
# ==============================================================================

set -e

NAMESPACE="banorte-ns"
LOG_FILE="runner.log"

# ==============================================================================
# CONFIGURACIÓN DE URL DE DESTINO (Soporte Puerto 443 / Local 8080)
# - Por defecto utiliza el entorno local a través del puerto 8080 (vía port-forward).
# - INSTRUCCIÓN: Si se desea apuntar el script a un entorno real 
#   o a una ruta segura en el puerto 443, puedes ejecutar el script sobrescribiendo
#   la variable de esta manera en tu terminal:
#   Ejemplo: TARGET_URL="https://tu-servidor-o-ingress:443" ./runner-kubernetes.sh
# ==============================================================================
TARGET_URL="${TARGET_URL:-http://localhost:8080}"

echo "=================================================="
echo "=== INICIANDO SIMULACIÓN DE PIPELINE CI/CD (DinD) ==="
echo "=================================================="

# 1. Login / Configuración del contexto y aplicación del YAML
echo "[1/4] Aplicando manifiesto de Kubernetes en el namespace '$NAMESPACE'..."
kubectl config set-context --current --namespace=$NAMESPACE
kubectl apply -f resources.yml

# 2. Exponer el servicio mediante port-forward en segundo plano (utilizado para pruebas locales)
echo "[2/4] Estableciendo puerto local (port-forward) para pruebas..."
kubectl port-forward deployment/prueba-especial-deployment 8080:8080 > /dev/null 2>&1 &
PF_PID=$!

# Esperar unos segundos a que se establezca la conexión
sleep 4

# 3. Realizar petición HTTP y almacenar la salida en runner.log
# Nota técnica: La especificación original solicita hacer curl a una ruta segura en el puerto 443 (<URL>:443).
# Gracias a la variable TARGET_URL superior, este script soporta de forma dinámica tanto 
# la validación local (8080) como la integración directa con rutas seguras en el puerto 443.
echo "[3/4] Ejecutando petición HTTP a '$TARGET_URL' y guardando en $LOG_FILE..."
echo "--- RESPUESTA HTTP (Destino: $TARGET_URL) ---" > $LOG_FILE
curl -s "$TARGET_URL" >> $LOG_FILE
echo "" >> $LOG_FILE
echo "--------------------------------------------------" >> $LOG_FILE

# 4. Validar la ejecución mediante RSH/Exec interno en el contenedor backend
echo "[4/4] Realizando validación interna (RSH/Exec) y extrayendo logs..."
echo "--- VALIDACIÓN DE PROCESOS / ESTADO INTERNO (EXEC) ---" >> $LOG_FILE
kubectl exec -it deployment/prueba-especial-deployment -c backend -- ps aux >> $LOG_FILE 2>&1 || true
echo "" >> $LOG_FILE
echo "--- LOGS DE LOS CONTENEDORES ---" >> $LOG_FILE
kubectl logs deployment/prueba-especial-deployment -c backend --tail=30 >> $LOG_FILE

# Limpiar el proceso de port-forward en segundo plano
kill $PF_PID 2>/dev/null || true

echo "=================================================="
echo "=== ¡PIPELINE FINALIZADO CON ÉXITO! ==="
echo "=== Revisa el archivo generado: $LOG_FILE ==="
echo "=================================================="