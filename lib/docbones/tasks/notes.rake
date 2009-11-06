

desc "Enumerate all annotations"
task :notes do |t|
  id = if t.application.top_level_tasks.length > 1
    t.application.top_level_tasks.slice!(1..-1).join(' ')
  end
  Docbones::AnnotationExtractor.enumerate(
      PROJ, PROJ.notes.tags.join('|'), id, :tag => true)
end

# EOF
