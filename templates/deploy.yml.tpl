kind: "Deployment"
apiVersion: "extensions/v1beta1"
metadata: 
  name: "api"
spec: 
  replicas: 1
  template: 
    metadata: 
      name: "api"
      labels: 
        app: "api"
        track: "stable"
    spec: 
      containers: 
        - name: "iapi"
          image: gcr.io/{{ PROJECT }}/api
          imagePullPolicy: "Always"
          ports: 
            - containerPort: 8080
          livenessProbe: 
            initialDelaySeconds: 30
            httpGet: 
              path: "/status"
              port: 8080
          resources: 
            requests: 
              memory: "100Mi"
          env: 
            - name: "ELASTIC_HOST"
              value: "elasticsearch"
            - name: "ELASTIC_PORT"
              value: "9200"
            - name: "ELASTIC_USER"
              value: ""
            - name: "ELASTIC_PASS"
              value: ""
            - name: "REDIS_MASTER_ADDRESS"
              value: "redis:6379"
            - name: "REDIS_CLIENT_ADDRESS"
              value: "redis:6379"
            - name: "DB_NAME"
              value: ""
            - name: "DATABASE_HOST"
              value: "{{ MYSQL_IP }}:3306"
            - name: "DATABASE_PROTOCOL"
              value: "tcp"
            - name: "DATABASE_USERNAME"
              value: "root"
            - name: "DATABASE_PASSWORD"
              value: ""
            - name: "MONGO_URL"
              value: "{{ MONGO_IP }}:27017"
            
