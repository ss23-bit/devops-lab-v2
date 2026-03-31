resource "aws_cloudfront_distribution" "web_cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Production Web CDN"

  # Where does CloudFront get the original website?
  origin {
    domain_name = aws_lb.frontend_alb.dns_name
    origin_id   = "ALB-Origin"

    custom_origin_config {
      http_port  = 80
      https_port = 443
      # Strict rule: We only opened port 80 on the ALB listener, so CloudFront must use HTTP to talk to it
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # What does CloudFront do with user requests
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"] # OPTIONS is check permissions.
    cached_methods   = ["GET", "HEAD"]            # Reads-Only
    target_origin_id = "ALB-Origin"

    forwarded_values {
      query_string = false # 1. E.g. "site.com/home?user" ignores the "?user=", for high speed. Everyone gets the same cached copy.
      cookies {
        forward = "none" # 2 .Maximum caching. Since there are no cookies to distinguished
        # The Risk 1.: If your app needs that "?user="" to show a personalized greeting, it won't work.
        # The Risk 2.: This will break your Login system. If your ALB needs a "Session Cookie" to know who is logged in
      }
    }

    viewer_protocol_policy = "allow-all" # Or "redirect-to-https": CloudFront automatically pushes them to the secure HTTPS version
    min_ttl                = 0
    default_ttl            = 3600  # Cache the site for 1 hour at the edge
    max_ttl                = 86400 # ttl = time to live
  }

  # Open to the world
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # *.cloudfront.net security for free.
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ===========================================================
# Route 53 (DNS Phonebook): Must purchase a real domain name.
# ===========================================================
/*
resource "aws_route53_zone" "main_domain" {
  name = "ss23-devops.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main_domain.zone_id
  name    = "www.ss23-devops.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.web_cdn.hosted_zone_id
    evaluate_target_health = true
  }
}
*/