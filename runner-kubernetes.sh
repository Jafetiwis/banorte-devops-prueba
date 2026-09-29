# ==============================================================================
# Script: runner-kubernetes.sh
# Descripción: Simulación de pipeline CI/CD (estilo GitLab CI) usando Kubernetes,
#              automatizando el despliegue, pruebas HTTP y captura de logs.
# ==============================================================================

# Salir inmediatamente si ocurre un error
set -e

NAMESPACE="banorte-ns"
LOG_FILE="runner.log"

echo "=================================================="
echo "=== INICIANDO SIMULACIÓN DE PIPELINE CI/CD (DinD) ==="
echo "=================================================="

# 1. Configurar contexto y aplicar el manifiesto de Kubernetes de la prueba anterior
echo "[1/4] Aplicando manifiesto de Kubernetes en el namespace '$NAMESPACE'..."
kubectl config set-context --current --namespace=$NAMESPACE
kubectl apply -f resources.yml

# 2. Exponer el servicio en segundo plano mediante port-forward (Puerto 8080)
echo "[2/4] Estableciendo puerto local (port-forward) para pruebas..."
kubectl port-forward deployment/prueba-especial-deployment 8080:8080 > /dev/null 2>&1 &
PF_PID=$!

# Esperar unos segundos a que se establezca la conexión del túnel
sleep 4

# 3. Realizar petición HTTP (curl) y almacenar la salida en runner.log
echo "[3/4] Ejecutando petición HTTP a la aplicación y guardando en $LOG_FILE..."
echo "--- RESPUESTA HTTP (curl localhost:8080) ---" > $LOG_FILE
curl -s http://localhost:8080 >> $LOG_FILE
echo "" >> $LOG_FILE
echo "--------------------------------------------------" >> $LOG_FILE

# 4. Validar la ejecución y extraer los logs internos de los contenedores
echo "[4/4] Extrayendo logs de los contenedores del deployment..."
echo "--- LOGS DEL CONTENEDOR BACKEND ---" >> $LOG_FILE
kubectl logs deployment/prueba-especial-deployment -c backend --tail=50 >> $LOG_FILE
echo "" >> $LOG_FILE
echo "--- LOGS DEL CONTENEDOR DATABASE ---" >> $LOG_FILE
kubectl logs deployment/prueba-especial-deployment -c database --tail=20 >> $LOG_FILE

# Limpiar el proceso de port-forward en segundo plano
kill $PF_PID 2>/dev/null || true

echo "=================================================="
echo "=== ¡PIPELINE FINALIZADO CON ÉXITO! ==="
echo "=== Revisa el archivo generado: $LOG_FILE ==="
echo "=================================================="