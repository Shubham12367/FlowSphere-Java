package com.flowsphere.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "approval_actions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApprovalAction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "request_id", nullable = false)
    private Request request;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stage_instance_id")
    private WorkflowStageInstance stageInstance;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "action_by_id", nullable = false)
    private User actionBy;

    @Column(nullable = false, length = 50)
    private String action; // SUBMITTED, APPROVED, REJECTED, CHANGES_REQUESTED, RESUBMITTED, COMPLETED

    @Column(length = 150)
    private String stageName;

    @Column(columnDefinition = "TEXT")
    private String comments;

    @Column(nullable = false)
    private LocalDateTime timestamp = LocalDateTime.now();

    public ApprovalAction(Request request, WorkflowStageInstance stageInstance, User actionBy, String action, String stageName, String comments) {
        this.request = request;
        this.stageInstance = stageInstance;
        this.actionBy = actionBy;
        this.action = action;
        this.stageName = stageName;
        this.comments = comments;
        this.timestamp = LocalDateTime.now();
    }
}
