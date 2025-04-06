import {
    create, mplCore, update,
    fetchAsset,
    fetchCollection,
    createCollection,
} from '@metaplex-foundation/mpl-core'
import {
    createGenericFile,
    generateSigner,
    signerIdentity,
    sol,
    keypairIdentity
} from '@metaplex-foundation/umi'
import { createUmi } from '@metaplex-foundation/umi-bundle-defaults'
import { base58 } from '@metaplex-foundation/umi/serializers'
import fs from 'fs'
import path from 'path'
import { irysUploader } from '@metaplex-foundation/umi-uploader-irys'
import { config } from 'dotenv'
config()

const createWildSolCollection = async () => {
	const umi = createUmi('https://api.devnet.solana.com')
		.use(mplCore())
		.use(
			irysUploader({
				// mainnet address: "https://node1.irys.xyz"
				// devnet address: "https://devnet.irys.xyz"
				address: 'https://devnet.irys.xyz',
			})
		)
    /*
    const signer = generateSigner(umi)
    umi.use(signerIdentity(signer))
    console.log('Airdropping 1 SOL to identity')
    await umi.rpc.airdrop(umi.identity.publicKey, sol(1))
    */
    //const privateKey = process.env.PRIVATE_KEY || ""
    //console.log('privateKey', privateKey)
    //const walletFile = JSON.parse(privateKey);
    const walletFile = JSON.parse(fs.readFileSync(path.join("./keypair.json"), "utf-8"));
    console.log('walletFile',walletFile)
    // Convert your walletFile onto a keypair.
    let keypair = umi.eddsa.createKeypairFromSecretKey(new Uint8Array(walletFile));
    //console.log('keypair', keypair)
    // Load the keypair into umi.
    umi.use(keypairIdentity(keypair));
    //
    // ** Upload an image to Arweave **
    //

    const imageFile = fs.readFileSync(
        path.join(__dirname, '..', 'my-image.png')
    )
    console.log("imageFile", imageFile)

    const umiImageFile = createGenericFile(imageFile, 'my-image.png', {
        tags: [{ name: 'Content-Type', value: 'image/png' }],
    })
    console.log("umiImageFile", umiImageFile)

    const imageUri = await umi.uploader.upload([umiImageFile]).catch((err) => {
        throw new Error(err)
    })

    console.log('imageUri: ' + imageUri[0])

    //
    // ** Upload Metadata to Arweave **
    //

    const metadata = {
        name: 'Wild SOL Collection',
        description: 'This is the Wild SOL Collection on Solana',
        image: imageUri[0],
        external_url: 'https://wild.sol',
        properties: {
            files: [
                {
                    uri: imageUri[0],
                    type: 'image/png',
                },
            ],
            category: 'image',
        },
    }

    console.log('Uploading Metadata...')
    const metadataUri = await umi.uploader.uploadJson(metadata).catch((err) => {
        throw new Error(err)
    })

    //
    // ** Creating the Collection **
    //

    const collection = generateSigner(umi)

    console.log('Creating Collection...')
    const tx = await createCollection(umi, {
        collection,
        name: 'My Collection',
        uri: metadataUri,
    }).sendAndConfirm(umi)

    const signature = base58.deserialize(tx.signature)[0]

    console.log('\Collection Created')
    console.log('View Transaction on Solana Explorer')
    console.log(`https://explorer.solana.com/tx/${signature}?cluster=devnet`)
    console.log('\n')
    console.log('View NFT on Metaplex Explorer')
    console.log(`https://core.metaplex.com/explorer/collection/${collection.publicKey}?env=devnet`)
}

createWildSolCollection()