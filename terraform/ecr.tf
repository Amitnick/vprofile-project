resource "aws_ecr_repository" "vpro-db" {
  name                 = "vpro-db"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = "vprofile"
  }
}

resource "aws_ecr_repository" "vpro-app" {
  name                 = "vpro-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = "vprofile"
  }
}
