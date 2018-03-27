--
-- Author: jinda.w
-- Date: 2017-11-07 09:49:57
--

-- //    0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,	    // 方块 A - K
-- //    0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,	    // 梅花 A - K
-- //    0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,	    // 红桃 A - K
-- //    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,	    // 黑桃 A - K
-- //    0x41,0x42,                                                             // 小王，大王
-- 		1 ~ 13
-- 		17 ~ 29
-- 		33 ~ 45
-- 		49 ~ 61
-- 		65 ~ 66

local config = {
	CT_ERROR          = 0,       -- 错误
	CT_SINGLE         = 1,       -- 单牌
	CT_DOUBLE         = 2,       -- 对子
	CT_THREE          = 3,		 -- 三
	CT_THREE_ONE      = 4,		 -- 三带一
	CT_THREE_DOUBLE   = 5,		 -- 三带二
	CT_SHUN_ZI        = 6,		 -- 顺子
	CT_SHUN_ZI_DOUBLE = 7,		 -- 双顺
	CT_FOUR_FOUR      = 8,		 -- 四带两对
	CT_FEIJI          = 9,       -- 飞机
	CT_FEIJI_ONE      = 10,      -- 飞机带单张
	CT_FEIJI_DOUBLE   = 11,      -- 飞机带对子
	CT_FOUR_DOUBLE    = 12,      -- 四带二
	CT_BOMB           = 13,      -- 炸弹
	CT_BOMB_KING      = 14,      -- 王炸


	
}

return config