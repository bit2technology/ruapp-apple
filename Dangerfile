
github.review.start

last_commit = git.commits.last
if last_commit.nil? || last_commit.message != 'Increase Build Number.'
  github.review.fail 'Please, increase build number before merging.'
end

swiftlint.lint_files(inline_mode: true)

github.review.submit
