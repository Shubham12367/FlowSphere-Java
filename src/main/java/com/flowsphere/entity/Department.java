package com.flowsphere.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "departments", uniqueConstraints = @UniqueConstraint(columnNames = "code"))
public class Department {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 10, unique = true)
    private String code;

    // Optional reference to department head user (one-to-one) – can be null initially
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "head_user_id")
    private User headUser;

    @OneToMany(mappedBy = "department", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<User> users = new HashSet<>();

    // Getters / Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public User getHeadUser() { return headUser; }
    public void setHeadUser(User headUser) { this.headUser = headUser; }
    public Set<User> getUsers() { return users; }
    public void setUsers(Set<User> users) { this.users = users; }
}
