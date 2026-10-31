package com.flowsphere.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.Set;

@Entity
@Table(name = "workflow_definitions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class WorkflowDefinition {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 100)
    private String category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private WorkflowStatus status = WorkflowStatus.ACTIVE;

    // One-to-many versions
    @OneToMany(mappedBy = "workflowDefinition", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<WorkflowVersion> versions;

    // Current active version (optional convenience)
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "current_version_id")
    private WorkflowVersion currentVersion;
}
