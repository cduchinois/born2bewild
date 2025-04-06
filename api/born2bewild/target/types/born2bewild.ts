/**
 * Program IDL in camelCase format in order to be used in JS/TS.
 *
 * Note that this is only a type helper and is not the actual IDL. The original
 * IDL can be found at `target/idl/born2bewild.json`.
 */
export type Born2bewild = {
  "address": "HhkSJ9aaJhHSkPfxDk29Mrzx2SNkf8Z6Sm8ZbQRMBKTq",
  "metadata": {
    "name": "born2bewild",
    "version": "0.1.0",
    "spec": "0.1.0",
    "description": "Created with Anchor"
  },
  "instructions": [
    {
      "name": "createDonationProject",
      "discriminator": [
        46,
        183,
        0,
        134,
        115,
        197,
        66,
        206
      ],
      "accounts": [
        {
          "name": "platform",
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  98,
                  111,
                  114,
                  110,
                  50,
                  98,
                  101,
                  119,
                  105,
                  108,
                  100
                ]
              },
              {
                "kind": "account",
                "path": "platform.name",
                "account": "config"
              }
            ]
          }
        },
        {
          "name": "project",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  112,
                  114,
                  111,
                  106,
                  101,
                  99,
                  116
                ]
              },
              {
                "kind": "arg",
                "path": "name"
              }
            ]
          }
        },
        {
          "name": "creator",
          "writable": true,
          "signer": true
        },
        {
          "name": "treasury",
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  116,
                  114,
                  101,
                  97,
                  115,
                  117,
                  114,
                  121
                ]
              },
              {
                "kind": "account",
                "path": "project"
              }
            ]
          }
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "name",
          "type": "string"
        },
        {
          "name": "description",
          "type": "string"
        },
        {
          "name": "location",
          "type": "string"
        },
        {
          "name": "targetAmount",
          "type": "u64"
        },
        {
          "name": "targetAnimal",
          "type": "string"
        }
      ]
    },
    {
      "name": "donate",
      "discriminator": [
        121,
        186,
        218,
        211,
        73,
        70,
        196,
        180
      ],
      "accounts": [
        {
          "name": "donor",
          "writable": true,
          "signer": true
        },
        {
          "name": "platform",
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  98,
                  111,
                  114,
                  110,
                  50,
                  98,
                  101,
                  119,
                  105,
                  108,
                  100
                ]
              },
              {
                "kind": "account",
                "path": "platform.name",
                "account": "config"
              }
            ]
          }
        },
        {
          "name": "wildTokenMint",
          "writable": true
        },
        {
          "name": "wildTokenAccount",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "account",
                "path": "donor"
              },
              {
                "kind": "const",
                "value": [
                  6,
                  221,
                  246,
                  225,
                  215,
                  101,
                  161,
                  147,
                  217,
                  203,
                  225,
                  70,
                  206,
                  235,
                  121,
                  172,
                  28,
                  180,
                  133,
                  237,
                  95,
                  91,
                  55,
                  145,
                  58,
                  140,
                  245,
                  133,
                  126,
                  255,
                  0,
                  169
                ]
              },
              {
                "kind": "account",
                "path": "wildTokenMint"
              }
            ],
            "program": {
              "kind": "const",
              "value": [
                140,
                151,
                37,
                143,
                78,
                36,
                137,
                241,
                187,
                61,
                16,
                41,
                20,
                142,
                13,
                131,
                11,
                90,
                19,
                153,
                218,
                255,
                16,
                132,
                4,
                142,
                123,
                216,
                219,
                233,
                248,
                89
              ]
            }
          }
        },
        {
          "name": "project",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  112,
                  114,
                  111,
                  106,
                  101,
                  99,
                  116
                ]
              },
              {
                "kind": "arg",
                "path": "projectName"
              }
            ]
          }
        },
        {
          "name": "treasury",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  116,
                  114,
                  101,
                  97,
                  115,
                  117,
                  114,
                  121
                ]
              },
              {
                "kind": "account",
                "path": "project"
              }
            ]
          }
        },
        {
          "name": "tokenProgram"
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        },
        {
          "name": "associatedTokenProgram",
          "address": "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL"
        }
      ],
      "args": [
        {
          "name": "projectName",
          "type": "string"
        },
        {
          "name": "amount",
          "type": "u64"
        }
      ]
    },
    {
      "name": "init",
      "discriminator": [
        220,
        59,
        207,
        236,
        108,
        250,
        47,
        100
      ],
      "accounts": [
        {
          "name": "admin",
          "writable": true,
          "signer": true
        },
        {
          "name": "born2bewild",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  98,
                  111,
                  114,
                  110,
                  50,
                  98,
                  101,
                  119,
                  105,
                  108,
                  100
                ]
              },
              {
                "kind": "arg",
                "path": "name"
              }
            ]
          }
        },
        {
          "name": "wildTokenMint",
          "writable": true,
          "signer": true
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        },
        {
          "name": "tokenProgram",
          "address": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
        },
        {
          "name": "rent",
          "address": "SysvarRent111111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "name",
          "type": "string"
        }
      ]
    },
    {
      "name": "withdraw",
      "discriminator": [
        183,
        18,
        70,
        156,
        148,
        109,
        161,
        34
      ],
      "accounts": [
        {
          "name": "platform",
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  98,
                  111,
                  114,
                  110,
                  50,
                  98,
                  101,
                  119,
                  105,
                  108,
                  100
                ]
              },
              {
                "kind": "account",
                "path": "platform.name",
                "account": "config"
              }
            ]
          }
        },
        {
          "name": "project",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  112,
                  114,
                  111,
                  106,
                  101,
                  99,
                  116
                ]
              },
              {
                "kind": "arg",
                "path": "projectName"
              }
            ]
          }
        },
        {
          "name": "treasury",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  116,
                  114,
                  101,
                  97,
                  115,
                  117,
                  114,
                  121
                ]
              },
              {
                "kind": "account",
                "path": "project"
              }
            ]
          }
        },
        {
          "name": "recipient",
          "writable": true,
          "signer": true
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "projectName",
          "type": "string"
        },
        {
          "name": "amount",
          "type": "u64"
        }
      ]
    }
  ],
  "accounts": [
    {
      "name": "config",
      "discriminator": [
        155,
        12,
        170,
        224,
        30,
        250,
        204,
        130
      ]
    },
    {
      "name": "donationProject",
      "discriminator": [
        175,
        114,
        164,
        20,
        58,
        182,
        229,
        118
      ]
    }
  ],
  "events": [
    {
      "name": "wildTokenCreated",
      "discriminator": [
        47,
        90,
        159,
        219,
        3,
        49,
        26,
        124
      ]
    },
    {
      "name": "wildTokenMinted",
      "discriminator": [
        187,
        84,
        178,
        246,
        148,
        111,
        82,
        132
      ]
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "unauthorizedWithdrawal",
      "msg": "Only the project creator can withdraw funds"
    },
    {
      "code": 6001,
      "name": "insufficientFunds",
      "msg": "Insufficient funds to withdraw"
    }
  ],
  "types": [
    {
      "name": "config",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "admin",
            "type": "pubkey"
          },
          {
            "name": "name",
            "type": "string"
          },
          {
            "name": "bump",
            "type": "u8"
          },
          {
            "name": "wildTokenMint",
            "type": "pubkey"
          }
        ]
      }
    },
    {
      "name": "donationProject",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "creator",
            "type": "pubkey"
          },
          {
            "name": "name",
            "type": "string"
          },
          {
            "name": "description",
            "type": "string"
          },
          {
            "name": "location",
            "type": "string"
          },
          {
            "name": "targetAmount",
            "type": "u64"
          },
          {
            "name": "targetAnimal",
            "type": "string"
          },
          {
            "name": "totalDonation",
            "type": "u64"
          },
          {
            "name": "projectBump",
            "type": "u8"
          },
          {
            "name": "treasuryBump",
            "type": "u8"
          }
        ]
      }
    },
    {
      "name": "wildTokenCreated",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "platform",
            "type": "pubkey"
          },
          {
            "name": "mint",
            "type": "pubkey"
          },
          {
            "name": "decimals",
            "type": "u8"
          },
          {
            "name": "timestamp",
            "type": "i64"
          }
        ]
      }
    },
    {
      "name": "wildTokenMinted",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "recipient",
            "type": "pubkey"
          },
          {
            "name": "amount",
            "type": "u64"
          },
          {
            "name": "donationAmount",
            "type": "u64"
          },
          {
            "name": "project",
            "type": "pubkey"
          },
          {
            "name": "timestamp",
            "type": "i64"
          }
        ]
      }
    }
  ]
};
