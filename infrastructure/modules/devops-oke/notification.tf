resource "oci_ons_notification_topic" "devops_notification_topic" {
    compartment_id = var.compartment_ocid
    name = var.devops_notification_topic_name
}

resource "oci_ons_subscription" "devops_notification_subscription_email" {
    count = var.devops_notification_subscription_endpoint_email != null ? 1 : 0
    compartment_id = var.compartment_ocid
    endpoint = var.devops_notification_subscription_endpoint_email
    protocol = "EMAIL"
    topic_id = oci_ons_notification_topic.devops_notification_topic.id
}

resource "oci_ons_subscription" "devops_notification_subscription_slack" {
    count = var.devops_notification_subscription_endpoint_slack != null ? 1 : 0
    compartment_id = var.compartment_ocid
    endpoint = var.devops_notification_subscription_endpoint_slack
    protocol = "SLACK"
    topic_id = oci_ons_notification_topic.devops_notification_topic.id
}