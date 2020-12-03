# awk -f day2_1.awk day2_input.txt
{
    char = substr($2, 1, 1)
    other_re = "[^" char "]"

    reps = $1
    sub("-", ",", reps)
    reps_re = "^" char "{" reps "}$"

    password = $3
    gsub(other_re, "", password)

    if (match(password, reps_re))
        valid++
}
END{print "Valid passwords: ", valid}
