log = (msg) -> console.log msg

padWithZeros = (length, string) ->
	while string.length < length
		string = '0' + string
	string

hex = (word) ->
	"0x#{padWithZeros 4, word.toString 16}"


opnames = [
	'ext'
	'set'
	'add'
	'sub'

	'mul'
	'div'
	'mod'
	'shl'

	'shr'
	'and'
	'bor'
	'xor'

	'ife'
	'ifn'
	'ifg'
	'ifb'
]

regnames = [
	'a', 'b', 'c',
	'x', 'y', 'z',
	'i', 'j'
]

valuenames = new Array(0x1d)
valuenames[0x18..0x1d] = [
	'[sp++]'
	'[sp]'
	'[--sp]'
	'sp'
	'pc'
	'o'
]

words = [0x7c01, 0x0030, 0x7dc1, 0x000d]
pos = 0
next = -> words[pos++]

printval = (value) ->
	if value in [0x00..0x07]
		regnames[value]
	else if value in [0x08..0x0f]
		'[' + regnames[value & 0x07] + ']'
	else if value in [0x10..0x17]
		"[#{hex next()} + " + regnames[value & 0x07] + ']'
	else if value in [0x18..0x1d]
		valuenames[value]
	else if value == 0x1e
		"[#{hex next()}]"
	else if value == 0x1f
		"#{hex next()}"
	else if value in [0x20..0x3f]
		hex value & 0x20
	else
		"unknown value #{hex value}"
#	value
#	if value 

decode = ->
	while word = next()
		take = (bits) ->
			mask = (1 << bits) - 1
			result = word & mask
			word >>= bits
	#		log "mask #{hex mask}, result #{hex result}, remnants of word #{hex word}"
			result

		op = take 4
		a = take 6
		b = take 6

		opname = opnames[op]
		aname = printval a
		bname = printval b

		log "  #{opname} #{aname}, #{bname}"

decode()
