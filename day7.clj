(ns day7)
(use '[clojure.string :only (join split)])

(defn parse [f]
  (into {}
        (comp
         (map #(split %  #" bags contain " 2))
         (map (fn [[n r]] [n (when-not (= r "no other bags.")
                               (map (fn [t]
                                      (#(vector (Integer/parseInt (first %))
                                                (join " " (butlast (rest %))))
                                       (split t #" ")))
                                    (split r #", ")))])))
        (line-seq (java.io.BufferedReader. f))))

(defn solve1 [[term & rest :as terms] result rules]
  (if term
    (let [inner (map first (filter #(some #{term} (map second (second %))) rules))]
      (solve1 (concat rest inner) (distinct (concat result inner)) rules))
    result))

(defn solve2 [bag rules]
  (inc (reduce + (map (fn [[c n]] (* c (solve2 n rules))) (rules bag)))))

(defn part1 [opts]
  (prn
   (count
    (solve1 ["shiny gold"] [] (parse *in*)))))

(defn part2 [opts]
  (prn
   (dec (solve2 "shiny gold" (parse *in*)))))
