// hoàn thiện code để module có thể publish được
module lesson6::hero_game {
    use sui::object::{Self, UID, ID};
    use std::string::String;
    use std::option::{Self, Option};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    // Điền thêm các ability phù hợp cho các object
    struct Hero has key, store {
        id: UID,
        name: String,
        game_id: ID,
        hp: u64,
        experience: u64,
        sword: Option<Sword>,
        armor: Option<Armor>
    }

    // Điền thêm các ability phù hợp cho các object
    struct Sword has key, store {
        id: UID,
        game_id: ID,
        attack: u64,
        strength: u64,
    }

    // Điền thêm các ability phù hợp cho các object
    struct Armor has key, store {
        id: UID,
        game_id: ID,
        defense: u64,
        strength: u64,
    }

    // Điền thêm các ability phù hợp cho các object
    struct Monter has key, store {
        id: UID,
        game_id: ID,
        hp: u64,
        strength: u64,
    }

    struct GameInfo has key {
        id: UID,
        admin: address
    }

    struct Admin has key, store {
        id: UID,
        /// ID of the game this admin manages
        game_id: ID,
        /// Total number of monster the admin has created
        monter_created: u64,
    }

    // hoàn thiện function để khởi tạo 1 game mới
    fun init(ctx: &mut TxContext) {
        let game_info = GameInfo {
            id: object::new(ctx),
            admin: tx_context::sender(ctx)
        };

        let admin = Admin {
            id: object::new(ctx),
            game_id: object::id(&game_info),
            monter_created: 0
        };

        transfer::share_object(game_info);
        transfer::transfer(admin, tx_context::sender(ctx));
    }

    // function để create các vật phẩm, nhân vật trong game.
    fun create_hero(name: String, sword: Sword, armor: Armor, ctx: &mut TxContext) : Hero {
        Hero {
            id: object::new(ctx),
            game_id: sword.game_id,
            name, 
            hp: 100,
            experience: 0,
            sword: option::some(sword),
            armor: option::some(armor)
        }
    }

    fun create_sword(game_info: &mut GameInfo, attack: u64, strength: u64, ctx: &mut TxContext) : Sword {
        Sword {
            id: object::new(ctx),
            attack,
            strength,
            game_id: object::id(game_info)
        }
    }
    fun create_armor(game_info: &mut GameInfo, defense: u64, strength: u64, ctx: &mut TxContext) : Armor {
        Armor {
            id: object::new(ctx),
            defense,
            strength,
            game_id: object::id(game_info)
        }
    }

    // function để create quái vật, chiến đấu với hero, chỉ admin mới có quyền sử dụng function này
    // Gợi ý: khởi tạo thêm 1 object admin.
    fun create_monter(
        admin: &mut Admin,
        hp: u64,
        strength: u64,
        ctx: &mut TxContext,
    ): Monter {
        admin.monter_created + 1;

        Monter {
            id: object::new(ctx),
            game_id: admin.game_id,
            hp,
            strength
        }
    }

    // func để tăng điểm kinh nghiệm cho hero sau khi giết được quái vật
    fun level_up_hero(hero: &Hero, exp: u64) {
        hero.experience + exp;
    }

    fun level_up_sword(sword: &Sword, attack: u64) {
        sword.attack + attack;
    }
    fun level_up_armor(armor: &Armor, defense: u64) {
        armor.defense + defense;
    }

    // Tấn công, hoàn thiện function để hero và monter đánh nhau
    // gợi ý: kiểm tra số điểm hp và strength của hero và monter, lấy hp trừ đi số sức mạnh mỗi lần tấn công. HP của ai về 0 trước người đó thua
    public entry fun attack_monter(hero: &mut Hero, monster: Monter) {
        let Monter {id: monster_id, hp: monster_hp, strength: monster_strength, game_id: _} = monster;

        let hero_hp = hero.hp;

        let hero_attack = if (option::is_some(&hero.sword)) {
                option::borrow(&hero.sword).attack
            } else {
                0
            };

        let hero_defense = if (option::is_some(&hero.armor)) {
                option::borrow(&hero.armor).defense
            } else {
                0
            };

        while (monster_hp > 0 && hero_hp > 0) {
            monster_hp - hero_attack;
            hero_hp + hero_defense - monster_strength;
        };

        object::delete(monster_id);

        if (hero_hp > 0) {
            level_up_hero(hero, 1);
            if (option::is_some(&hero.sword)) {
                level_up_sword(option::borrow_mut(&mut hero.sword), 1);
            };
            if (option::is_some(&hero.armor)) {
                level_up_armor(option::borrow_mut(&mut hero.armor), 1);
            };
        }
    }

}
