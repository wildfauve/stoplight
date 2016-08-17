class TemplateFactory

  def call(event)
    Container.resolve(template_slug(event.kind))
  end

  def template_slug(kind)
    "templates.#{kind.gsub(".","_")}_template"
  end

end
