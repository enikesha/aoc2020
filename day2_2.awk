# awk -f day2_2.awk day2_input.txt
{
    split($1, indices, "-")
    char = substr($2, 1, 1)
    pass = $3

    first = substr(pass, indices[1], 1)
    second = substr(pass, indices[2], 1)

    #print $0, char, first, second
    if ((first == char && second != char) || (first != char && second == char))
        valid++
}
END{print "Valid passwords: ", valid}
