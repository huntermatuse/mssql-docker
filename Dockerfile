FROM --platform=linux/amd64 mcr.microsoft.com/mssql/server:2025-latest

USER root

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=${SA_PASSWORD:-Str0ng!Passw0rd}
ENV SQLCMDPASSWORD=${SA_PASSWORD}
ENV MSSQL_PID=${MSSQL_PID:-Developer}
ENV INSERT_SIMULATED_DATA=${INSERT_SIMULATED_DATA:-false}

# Copy in scripts
COPY docker-entrypoint.sh /
COPY healthcheck.sh /
COPY scripts /scripts
RUN sed -i 's/\r$//' /docker-entrypoint.sh /healthcheck.sh && chmod +x /docker-entrypoint.sh /healthcheck.sh

# Set a Simple Health Check
HEALTHCHECK \
    --interval=30s \
    --retries=3 \
    --start-period=10s \
    --timeout=30s \
    CMD /healthcheck.sh

# Put CLI tools on the PATH
ENV PATH=/opt/mssql-tools18/bin:$PATH

# Create some base paths and place our provisioning script
RUN mkdir /docker-entrypoint-initdb.d && \
    chown mssql:root /docker-entrypoint-initdb.d && \
    mkdir /backups && \
    chown mssql:root /backups && \
    mkdir -p /var/opt/mssql

# Return to mssql user
USER mssql

# Run SQL Server process.
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/opt/mssql/bin/sqlservr" ]