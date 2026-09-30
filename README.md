## 📦 Detalle de las Pruebas Implementadas

### **Prueba 1: Contenerización de Aplicación Web**
* **Tecnologías:** Node.js, Alpine Linux, Docker.
* **Descripción:** Se desarrolló un servicio backend modular que expone endpoints HTTP dinámicos respondiendo con la identidad institucional y marcas temporales de ejecución.
* **Buenas Prácticas:** Uso de imágenes base ligeras (`node:alpine`) para reducir la superficie de ataque y optimizar tiempos de despliegue.

### **Prueba 2: Infraestructura y Orquestación en Kubernetes**
* **Tecnologías:** Kubernetes, PostgreSQL 15, PersistentVolumeClaims.
* **Descripción:** Despliegue centralizado y declarativo mediante el manifiesto **`resources.yml`** confinado en el namespace `banorte-ns`.
* **Componentes Clave:**
  * **`db-secret`:** Cifrado de credenciales críticas (`temp4now`).
  * **`db-config`:** Variables de entorno desacopladas.
  * **`postgres-pvc`:** Aprovisionamiento de almacenamiento persistente de 1 GB para garantizar la integridad de transacciones de base de datos.
  * **Deployment Multi-contenedor:** Co-ubicación segura del motor relacional y el servicio de aplicación.

### **Prueba 3: Automatización de Pipeline CI/CD (DinD Simulation)**
* **Tecnologías:** Bash Scripting, kubectl, Docker-in-Docker.
* **Descripción:** Automatización robusta a través del script **`runner-kubernetes.sh`**, simulando un Runner de CI/CD (estilo GitLab CI) en ausencia temporal de infraestructura dedicada.
* **Características Avanzadas:**
  * **Idempotencia:** Aplica configuraciones asegurando un estado deseado consistente.
  * **Soporte de Puertos Dinámico:** Variable configurable `TARGET_URL` (por defecto `http://localhost:8080` vía port-forward, totalmente compatible con entornos que expongan rutas seguras en el puerto estándar `443`).
  * **Auditoría y Trazabilidad:** Generación automática del archivo **`runner.log`** conteniendo la respuesta HTTP y la validación de procesos internos mediante `kubectl exec` (RSH).

### **Prueba 4: SecOps & Despliegue de Seguridad (Burp Suite Enterprise)**
* **Tecnologías:** Helm Charts, PortSwigger Enterprise Server, Kubernetes.
* **Descripción:** Configuración orientada al análisis de vulnerabilidades automatizado (DAST).
* **Entregables:** 
  * Archivo **`burp/values.yml`** estructurado con los parámetros corporativos de bases de datos internas y persistencia de 10Gi.
  * Guía técnica en **`SECOPS.md`** con los comandos exactos de ciclo de vida (Instalación, Verificación y Desinstalación limpia).