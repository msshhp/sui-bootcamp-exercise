// Hoàn thiện đoạn code để có thể publish được
module lesson5::FT_TOKEN {
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, TreasuryCap, Coin, CoinMetadata};
    use std::option::{Self, Option};
    use sui::url::{Self, Url};
    use sui::transfer;
    use std::string::{Self, String};
    use sui::event;
    use std::ascii;

    struct FT_TOKEN has drop { }

    fun init(witness: FT_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<FT_TOKEN>(
            witness, 18, b"MSSHHP", b"MSSHHP", b"My token",
            option::some(url::new_unsafe_from_bytes(b"https://sui.directory/wp-content/uploads/2023/04/Sui_Favicon_256.png")),
            ctx
        );
        transfer::public_transfer(metadata, tx_context::sender(ctx));
        transfer::public_share_object(treasury_cap);
    }

    // hoàn thiện function để có thể tạo ra 10_000 token cho mỗi lần mint, và mỗi owner của token mới có quyền mint
    public fun mint(_: &CoinMetadata<FT_TOKEN>, treasury_cap: &mut TreasuryCap<FT_TOKEN>, recipient: address, ctx: &mut TxContext) {
        coin::mint_and_transfer(treasury_cap, 10_000, recipient, ctx);
        event::emit(UpdateEvent {
            success: true,
            data: string::utf8(b"10000 tokens minted")
        })
    }

    // Hoàn thiện function sau để user hoặc ai cũng có quyền tự đốt đi số token đang sở hữu
    public entry fun burn_token(treasury_cap: &mut TreasuryCap<FT_TOKEN>, coin: Coin<FT_TOKEN>) {
        coin::burn(treasury_cap, coin);
        event::emit(UpdateEvent {
            success: true,
            data: string::utf8(b"Tokens burned")
        })
    }

    // Hoàn thiện function để chuyển token từ người này sang người khác.
    public entry fun transfer_token(coin: Coin<FT_TOKEN>, recipient: address) {
        transfer::public_transfer(coin, recipient);
        // sau đó khởi 1 Event, dùng để tạo 1 sự kiện khi function transfer được thực thi
        event::emit(UpdateEvent {
            success: true,
            data: string::utf8(b"Tokens transfered")
        })
    }

    // Hoàn thiện function để chia Token Object thành một object khác dùng cho việc transfer
    // gợi ý sử dụng coin:: framework
    public fun split_token(coin: &mut Coin<FT_TOKEN>, split_amount: u64, ctx: &mut TxContext): Coin<FT_TOKEN> {
        event::emit(UpdateEvent {
            success: true,
            data: string::utf8(b"Tokens splitted")
        });
        coin::split(coin, split_amount, ctx)
    }

    // Viết thêm function để token có thể update thông tin sau

    public entry fun update_name(treasury: &TreasuryCap<FT_TOKEN>, metadata: &mut CoinMetadata<FT_TOKEN>, name: String) {
        coin::update_name(treasury, metadata, name);
        event::emit(UpdateEvent {
            success: true,
            data: name
        });
    }

    public entry fun update_description(treasury: &TreasuryCap<FT_TOKEN>, metadata: &mut CoinMetadata<FT_TOKEN>, description: String) {
        coin::update_description(treasury, metadata, description);
        event::emit(UpdateEvent {
            success: true,
            data: description
        });
    }

    public entry fun update_symbol(treasury: &TreasuryCap<FT_TOKEN>, metadata: &mut CoinMetadata<FT_TOKEN>, symbol: ascii::String) {
        coin::update_symbol(treasury, metadata, symbol);
        let toByteSymbol = ascii::into_bytes(symbol);
        event::emit(UpdateEvent {
            success: true,
            data: string::utf8(toByteSymbol)
        });
    }
    public entry fun update_icon_url(treasury: &TreasuryCap<FT_TOKEN>, metadata: &mut CoinMetadata<FT_TOKEN>, url: ascii::String) {
        coin::update_icon_url(treasury, metadata, url);
        let toByteUrl = ascii::into_bytes(url);
        event::emit(UpdateEvent {
            success: true,
            data: string::utf8(toByteUrl)
        });
    }

    // sử dụng struct này để tạo event cho các function update bên trên.
    struct UpdateEvent has copy, drop {
        success: bool,
        data: String
    }

    // Viết các function để get dữ liệu từ token về để hiển thị
    public entry fun get_token_name(metadata: &CoinMetadata<FT_TOKEN>): String {
        coin::get_name(metadata)
    }
    public entry fun get_token_description(metadata: &CoinMetadata<FT_TOKEN>): String {
        coin::get_description(metadata)
    }
    public entry fun get_token_symbol(metadata: &CoinMetadata<FT_TOKEN>): ascii::String {
        coin::get_symbol(metadata)
    }
    public entry fun get_token_icon_url(metadata: &CoinMetadata<FT_TOKEN>): Option<Url> {
        coin::get_icon_url(metadata)
    }
}
