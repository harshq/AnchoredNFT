package models

type ItemListed struct {
	RindexerID      int64   `gorm:"column:rindexer_id;primaryKey;autoIncrement" json:"rindexer_id"`
	ContractAddress string  `gorm:"column:contract_address;type:char(66);not null" json:"contract_address"`
	TokenAddress    *string `gorm:"column:token_address;type:char(42)" json:"token_address,omitempty"`
	TokenID         *string `gorm:"column:token_id;type:varchar(78)" json:"token_id,omitempty"`
	TxHash          string  `gorm:"column:tx_hash;type:char(66);not null" json:"tx_hash"`
	BlockNumber     string  `gorm:"column:block_number;type:numeric;not null" json:"block_number"`
	BlockHash       string  `gorm:"column:block_hash;type:char(66);not null" json:"block_hash"`
	Network         string  `gorm:"column:network;type:varchar(50);not null" json:"network"`
	TxIndex         string  `gorm:"column:tx_index;type:numeric;not null" json:"tx_index"`
	LogIndex        string  `gorm:"column:log_index;type:varchar(78);not null" json:"log_index"`
	Price           *string `gorm:"column:price;type:varchar(78)" json:"price,omitempty"`
}

func (ItemListed) TableName() string {
	return "marketplace_nft_marketplace.item_listed"
}
