package com.ivandelic.micro.cloudnativestars;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController()
@RequestMapping(path = "/departments", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class DepartmentController {

    @Autowired
    DepartmentRepository departmentRepository;

    @GetMapping("")
    @ResponseBody ResponseEntity<List<Department>> list() {
        List<Department> departments = departmentRepository.findAll();
        return new ResponseEntity<>(departments, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public @ResponseBody ResponseEntity<Department> getById(@PathVariable String id) {
        Optional<Department> department = departmentRepository.findById(id);
        if (department.isPresent()) {
            return new ResponseEntity<>(department.get(), HttpStatus.OK);
        } else {
            throw new RecordNotFoundException("Not Found");
        }
    }

    @PutMapping("/")
    public @ResponseBody ResponseEntity<Department> insert(@RequestBody Department input) {
        Department department = departmentRepository.insert(input);
        return new ResponseEntity<>(department, HttpStatus.CREATED);
    }

    @PostMapping("/")
    public @ResponseBody ResponseEntity<Department> save(@RequestBody Department input) {
        Department department = departmentRepository.save(input);
        return new ResponseEntity<>(department, HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}")
    public @ResponseBody ResponseEntity delete(@PathVariable String id) {
        departmentRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
