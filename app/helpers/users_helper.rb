module UsersHelper
  ROLE_BADGE_CLASSES = {
    "author" => "role-badge role-badge--author",
    "admin" => "role-badge role-badge--admin"
  }.freeze

  def role_badge(role)
    label = role.to_s.titleize
    css = ROLE_BADGE_CLASSES.fetch(role.to_s, ROLE_BADGE_CLASSES["author"])
    content_tag(:span, label, class: css)
  end
end
