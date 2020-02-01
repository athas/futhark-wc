type char_type = #is_space | #not_space
type flux = #flux char_type i32 char_type | #unknown

let flux_mappend (x: flux) (y: flux): flux =
  match (x,y)
  case (#unknown, _) -> y
  case (_, #unknown) -> x
  case (#flux l n #not_space,
        #flux #not_space n' r) ->
    #flux l (n + n' - 1) r
  case (#flux l n _ ,
        #flux _ n' r) ->
    #flux l (n + n') r

let flux_mempty : flux = #unknown

let is_space (c: u8) = c == 9 || c == 10 || c == 32

let flux (c: u8) : flux =
  if is_space c
  then #flux #is_space 0 #is_space
  else #flux #not_space 1 #not_space

type counts = { chars: i32
              , words: flux
              , lines: i32 }

let counts_mappend (x: counts) (y: counts) =
  { chars = x.chars + y.chars,
    words = x.words `flux_mappend` y.words,
    lines = x.lines + y.lines }

let counts_mempty : counts =
  { chars = 0, words = flux_mempty, lines = 0 }

let count_char (c: u8) : counts =
  { chars = 1, words = flux c, lines = if c == 10 then 1 else 0 }

entry wc [n] (cs: [n]u8) : (i32, i32, i32) =
  (length cs,

   map3 (\i prev this ->
           i32.bool ((i == 0 && !(is_space this))
                     || is_space prev && !(is_space this)))
        (iota n) cs (rotate 1 cs)
   |> i32.sum,

   cs |> map ((==10) >-> i32.bool) |> i32.sum)
