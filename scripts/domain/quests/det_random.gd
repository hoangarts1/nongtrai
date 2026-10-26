## DetRandom — stable seeded streams for Phase 8 daily stock.
## API:
##   static func make_rng(world_seed: int, day: int, tag: int) -> RandomNumberGenerator
class_name DetRandom
extends RefCounted

const TAG_MERCHANT: int = 8
const MOD: int = 2147483647

static func mix(a: int, b: int) -> int:
	return posmod(posmod(a, MOD) * 1103515245 + posmod(b, MOD) + 12345, MOD)

static func make_rng(world_seed: int, day: int, tag: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = mix(mix(world_seed, day), tag)
	return rng
