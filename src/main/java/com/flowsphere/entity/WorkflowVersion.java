package com.flowsphere.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "workflow_versions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class WorkflowVersion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workflow_definition_id", nullable = false)
    private WorkflowDefinition workflowDefinition;

    @Column(nullable = false)
    private Integer versionNumber;

    // JSON columns storing stage definitions and transitions; using String for simplicity (will map to JSON in DB)
    @Column(columnDefinition = "TEXT")
    private String stagesJson;

    @Column(columnDefinition = "TEXT")
    private String transitionsJson;

    @Column(columnDefinition = "TEXT")
    private String slaConfigJson;
}
