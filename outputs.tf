# -------------------------------
#  Outputs
# -------------------------------
output target_group_arn {
  value       = element(concat(aws_alb_target_group.main.*.arn, [""]), 0)
  description = "target group's arn"
}

output target_group_arn_suffix {
  value       = element(concat(aws_alb_target_group.main.*.arn_suffix, [""]), 0)
  description = "target group's arn suffix"
}

