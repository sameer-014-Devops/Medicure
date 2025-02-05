#!/bin/bash

# Automatically select the first JAR file in the directory
Wrk_Dir="/opt/tomcat/webapps"
JAR_FILE=$(ls "$Wrk_Dir"/medicure-*.jar 2>/dev/null | sort -V | tail -n 1)
PID_FILE="$Wrk_Dir/app.pid"

# Check if a JAR file exists
if [ -z "$JAR_FILE" ]; then
    echo "No JAR file found in the current directory."
    exit 1
fi

case "$1" in
    start)
        if [ -f "$PID_FILE" ]; then
            echo "Application is already running (PID: $(cat $PID_FILE))."
        else
            echo "Starting the application with $JAR_FILE..."
            nohup java -jar "$JAR_FILE" > output.log 2>&1 &
            echo $! > "$PID_FILE"
            sleep 2
            if ps -p $(cat "$PID_FILE") > /dev/null; then
                echo "Application started successfully (PID: $(cat $PID_FILE))."
            else
                echo "Failed to start the application. Check output.log for errors."
                rm -f "$PID_FILE"
            fi
        fi
        ;;
    
    stop)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            echo "Stopping application with PID $PID..."
            kill $PID
            sleep 2
            if ps -p $PID > /dev/null; then
                echo "Failed to stop the application. Forcing termination..."
                kill -9 $PID
            else
                echo "Application stopped successfully."
            fi
            rm -rf "$PID_FILE"
            rm -rf output.log
        else
            echo "No running application found."
        fi
        ;;
    
    status)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if ps -p $PID > /dev/null; then
                echo "Application is running (PID: $PID)."
            else
                echo "PID file exists but application is not running."
                rm -f "$PID_FILE"
            fi
        else
            echo "Application is not running."
        fi
        ;;
    
    *)
        echo "Usage: $0 {start|stop|status}"
        ;;
esac
