package com.ivandelic.micro.cloudnativestars;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document("departments")
public class Department {
    @Id
    private String id;
    private String name;
    private int code;
    private String description;

    public Department(String id, String name, int code, String description) {
        super();
        this.id = id;
        this.name = name;
        this.code = code;
        this.description = description;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
