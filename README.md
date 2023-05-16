I know this isn't the cleanest Ruby, but I wanted to push my solution through
to something that really worked.

If you open the root directory and simply run `ruby build_leader_boards.rb`,
then it should return something that looks like the following:

```
{:campaign_id=>"16", :display=>[{:team_supporting=>"Area of Greatest Need", :donor_count=>3, :raised_amt=>72000}, {:team_supporting=>"Mission and Ministry", :donor_count=>1, :raised_amt=>2000}, {:team_supporting=>"Student Financial Aid", :donor_count=>2, :raised_amt=>1750}, {:team_supporting=>"College of Veterinary Medicine", :donor_count=>1, :raised_amt=>1250}, {:team_supporting=>"Athletics", :donor_count=>1, :raised_amt=>150}]}
{:campaign_id=>"18", :display=>[{:team_supporting=>"College of Education", :donor_count=>1, :raised_amt=>2000}]}
{:campaign_id=>"25", :display=>[{:team_supporting=>"College of Veterinary Medicine", :donor_count=>1, :raised_amt=>19}]}
{:campaign_id=>"20", :display=>[]}
```

The campaign id is obviously the campaign that the leaderboard is associated with
The `display` array is what should actually be displayed for that leader board.
`team_supporting` corresponds to the "What team are you supporting?" column
`donor_count` is the total number of unique donors to that area
`raised_amt` corresponds to the "$Raised" column

I also noticed that there are some potential duplicate pieces of data between
the two CSVs, such as Ken Erickson making identical donations in each of them.
I've chosen not to combine these because offline and online donations should
be independent of one another. I'm choosing to see it as a case of Ken made a
huge donation, then someone called him and got him to match it again offline,
or something along those lines.
