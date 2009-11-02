
if HAVE_BONES

namespace :docbones do

  desc 'Show the PROJ open struct'
  task :debug do |t|
    atr = if t.application.top_level_tasks.length == 2
      t.application.top_level_tasks.pop
    end

    if atr then Docbones::Debug.show_attr(PROJ, atr)
    else Docbones::Debug.show PROJ end
  end

end  # namespace :docbones

end  # HAVE_BONES

# EOF
