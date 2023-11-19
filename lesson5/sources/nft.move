module lesson5::discount_coupon {
    use sui::object::{Self, UID};
    use sui::coin;
    use sui::sui::SUI;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::clock::{Self, Clock};

    struct DiscountCoupon has key, store {
        id: UID,
        owner: address,
        discount: u8,
        expiration: u64,
    }

    const EExpiredDiscount: u64 = 0;
    const EOutOfRangeDiscount: u64 = 1;

    /// Lấy thông tin của người sở hữu
    public fun owner(coupon: &DiscountCoupon): address {
        coupon.owner
    }

    /// Lấy thông tin discount của coupon
    public fun discount(coupon: &DiscountCoupon): u8 {
        coupon.discount
    }

    // Hoàn thiện function để mint 1 coupon và transfer coupon này cho một người nhận recipient
    public entry fun mint_and_topup(
        coin: coin::Coin<SUI>,
        discount: u8,
        expiration: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let coupon = DiscountCoupon {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            discount,
            expiration,
        };
        transfer::transfer(coupon, recipient);
        transfer::public_transfer(coin, recipient);
    }

    // hoàn thiện function để có thể transfer coupon cho 1 người khác
    public entry fun transfer_coupon(coupon: DiscountCoupon, recipient: address) {
        transfer::public_transfer(coupon, recipient);
    }

    // Hoàn thiện function đê huỷ, xoá đi coupon.
    public entry fun burn(nft: DiscountCoupon) {
        let DiscountCoupon { id, owner: _, discount: _, expiration: _ } = nft;
        object::delete(id);
    }

    // Hoàn thiện function để người dùng sử dụng, sau đó sẽ xoá đi cái coupon
    public entry fun scan(nft: DiscountCoupon, clock: &Clock) {
        // ....check information
        assert!(nft.expiration >= clock::timestamp_ms(clock), EExpiredDiscount);
        assert!(nft.discount > 0 && nft.discount <= 100, EOutOfRangeDiscount);

        burn(nft);
    }
}
