# Documentación SecOps - Burp suite Enterprise

# comando de instalación:
 helm install burp-enterprise PortSwigger/burp-enterprise-suite -f burp/values.yml --namespace secops-ns --create-namespace

# comando de Verificación de Estado:
 kubectl get all -n secops-ns

# comando de Desinstalación
 helm uninstall burp-enterprise --namespace secops-ns
 kubectl delete namespace secops-ns