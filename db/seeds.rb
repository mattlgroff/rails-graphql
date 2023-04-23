# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

matt = Person.create!(
  first_name: "Matt",
  last_name: "Groff",
  email: "matt@umbrage.com",
  job_title: "Director of Engineering",
  avatar: "https://www.gravatar.com/avatar/b21bbd4c0b7f75a0fbb469c238639eb7"
)

Comment.create!(
  [
    {
      person: matt,
      comment: "This is a comment from Matt Groff",
    },
    {
      person: matt,
      comment: "This is another comment from Matt Groff",
    }
  ]
)