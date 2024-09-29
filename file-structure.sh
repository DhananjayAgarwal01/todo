#!/bin/bash
# This script creates the full project structure for the to-do list app, including files

# Root directory
mkdir todo-list-project
cd todo-list-project

# Java Backend
mkdir -p java-backend/src/main/java/com/example/todo
mkdir -p java-backend/src/main/resources/static
mkdir -p java-backend/src/test

# Create Java Backend files
cat <<EOL > java-backend/src/main/java/com/example/todo/Application.java
package com.example.todo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
EOL

cat <<EOL > java-backend/src/main/java/com/example/todo/Task.java
package com.example.todo.model;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
public class Task {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String task;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTask() { return task; }
    public void setTask(String task) { this.task = task; }
}
EOL

cat <<EOL > java-backend/src/main/java/com/example/todo/TaskRepository.java
package com.example.todo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.example.todo.model.Task;

public interface TaskRepository extends JpaRepository<Task, Long> {}
EOL

cat <<EOL > java-backend/src/main/java/com/example/todo/TaskController.java
package com.example.todo.controller;

import com.example.todo.model.Task;
import com.example.todo.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tasks")
public class TaskController {

    @Autowired
    private TaskRepository taskRepository;

    @GetMapping
    public List<Task> getAllTasks() {
        return taskRepository.findAll();
    }

    @PostMapping
    public Task createTask(@RequestBody Task task) {
        return taskRepository.save(task);
    }

    @DeleteMapping("/{id}")
    public void deleteTask(@PathVariable Long id) {
        taskRepository.deleteById(id);
    }
}
EOL

cat <<EOL > java-backend/src/main/resources/application.properties
spring.h2.console.enabled=true
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=update
EOL

cat <<EOL > java-backend/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>todo</artifactId>
    <version>1.0-SNAPSHOT</version>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.5</version>
    </parent>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
    </dependencies>
</project>
EOL

# Flask Frontend
mkdir -p flask-frontend/templates
mkdir flask-frontend/static

# Create Flask Frontend files
cat <<EOL > flask-frontend/app.py
from flask import Flask, render_template, request, jsonify
import requests

app = Flask(__name__)

JAVA_API_URL = 'http://localhost:8080/tasks'

@app.route('/')
def index():
    response = requests.get(JAVA_API_URL)
    tasks = response.json()
    return render_template('index.html', tasks=tasks)

@app.route('/add', methods=['POST'])
def add_task():
    task = request.form['task']
    requests.post(JAVA_API_URL, json={'task': task})
    return jsonify({'status': 'success'})

@app.route('/delete/<task_id>', methods=['POST'])
def delete_task(task_id):
    requests.delete(f"{JAVA_API_URL}/{task_id}")
    return jsonify({'status': 'success'})

if __name__ == '__main__':
    app.run(debug=True)
EOL

cat <<EOL > flask-frontend/templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>To-Do List</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1 class="text-center">To-Do List</h1>
        <form id="add-task-form" class="my-3">
            <div class="input-group">
                <input type="text" class="form-control" name="task" placeholder="Add new task" required>
                <button class="btn btn-success" type="submit">Add Task</button>
            </div>
        </form>

        <ul class="list-group">
            {% for task in tasks %}
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    {{ task.task }}
                    <button class="btn btn-danger btn-sm delete-task" data-id="{{ task.id }}">Delete</button>
                </li>
            {% endfor %}
        </ul>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.querySelectorAll('.delete-task').forEach(button => {
            button.addEventListener('click', function() {
                const taskId = this.dataset.id;
                fetch(\`/delete/\${taskId}\`, { method: 'POST' }).then(() => location.reload());
            });
        });

        document.getElementById('add-task-form').addEventListener('submit', function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            fetch('/add', {
                method: 'POST',
                body: formData
            }).then(() => location.reload());
        });
    </script>
</body>
</html>
EOL

cat <<EOL > flask-frontend/requirements.txt
Flask
requests
EOL

# Create README file
cat <<EOL > README.md
# To-Do List Application

This is a to-do list application that uses a Java backend (Spring Boot) and Flask for the frontend. The frontend is styled using Bootstrap.

## Structure
- **Java Backend**: Handles the to-do tasks using a REST API.
- **Flask Frontend**: Renders the frontend and communicates with the Java backend.

## Setup

### Java Backend:
- Navigate to the `java-backend` folder and run the following command:
  \`mvn spring-boot:run\`

### Flask Frontend:
- Navigate to the `flask-frontend` folder and run the following command:
  \`python app.py\`

Visit the frontend at `http://localhost:5000`.
EOL

# End message
echo "Project folder structure and files created successfully!"
