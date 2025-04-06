import { create, mplCore, update,
	fetchAsset,
	fetchCollection,
 } from '@metaplex-foundation/mpl-core'
import {
	createGenericFile,
	generateSigner,
	signerIdentity,
	keypairIdentity,
	sol,
	publicKey as UMIPublicKey,
} from '@metaplex-foundation/umi'
import { irysUploader } from '@metaplex-foundation/umi-uploader-irys'
import { createUmi } from '@metaplex-foundation/umi-bundle-defaults'
import { base58 } from '@metaplex-foundation/umi/serializers'
import fs from 'fs'
import path from 'path'
import { config } from 'dotenv'
import {
	airdropIfRequired,
	getExplorerLink,
	getKeypairFromFile,
  } from "@solana-developers/helpers";

config()

export const updateNft = async (address: string, metadata: any): Promise<string> => {
	const umi = createUmi('https://api.devnet.solana.com')
		.use(mplCore())
		.use(
			irysUploader({
				// mainnet address: "https://node1.irys.xyz"
				// devnet address: "https://devnet.irys.xyz"
				address: 'https://devnet.irys.xyz',
			})
		)

	// You will need to us fs and navigate the filesystem to
	// load the wallet you wish to use via relative pathing.	
	//const walletFile = fs.readFileSync('./keypair.json')
	const privateKey = process.env.PRIVATE_KEY || ""
	//console.log('privateKey', privateKey)
	const walletFile = JSON.parse(privateKey);
	//const walletFile = JSON.parse(fs.readFileSync(path.join("./keypair.json"), "utf-8"));
	//.log('walletFile',walletFile)

	// Convert your walletFile onto a keypair.
	let keypair = umi.eddsa.createKeypairFromSecretKey(new Uint8Array(walletFile));
	//console.log('keypair', keypair)
	// Load the keypair into umi.
	umi.use(keypairIdentity(keypair));
	
  //const signer = generateSigner(umi)
  //umi.use(signerIdentity(signer))
  /*
  // Airdrop 1 SOL to the identity
  // if you end up with a 429 too many requests error, you may have to use
  // the filesystem wallet method or change rpcs.
  console.log('Airdropping 1 SOL to identity')
  await umi.rpc.airdrop(umi.identity.publicKey, sol(1))
		*/

	//
	// ** Upload an image to Arweave **
	//

	// use `fs` to read file via a string path.
	// You will need to understand the concept of pathing from a computing perspective.

	/*
	const imageFile = fs.readFileSync(
		path.join('./image.jpg')
	)

	console.log("imageFile", imageFile)

	// Use `createGenericFile` to transform the file into a `GenericFile` type
	// that umi can understand. Make sure you set the mimi tag type correctly
	// otherwise Arweave will not know how to display your image.

	const umiImageFile = createGenericFile(imageFile, 'image.jpg', {
		tags: [{ name: 'Content-Type', value: 'image/jpeg' }],
	})

	console.log('umiImageFile', umiImageFile)

	// Here we upload the image to Arweave via Irys and we get returned a uri
	// address where the file is located. You can log this out but as the
	// uploader can takes an array of files it also returns an array of uris.
	// To get the uri we want we can call index [0] in the array.
	console.log('Uploading Image...')
	const imageUri = await umi.uploader.upload([umiImageFile]).catch((err) => {
		throw new Error(err)
	})

	console.log('imageUri: ' + imageUri[0])

	
	//
	// ** Upload Metadata to Arweave **
	//
	const metadata = {
		name: 'Armandos updated NFT',
		description: 'This is an UPDATED NFT on Solana',
		image: imageUri[0],
		external_url: 'https://example.com',
		attributes: [
			{
				trait_type: 'trait1',
				value: 'value1',
			},
			{
				trait_type: 'trait2',
				value: 'value2',
			},
		],
		properties: {
			files: [
				{
					uri: imageUri[0],
					type: 'image/jpeg',
				},
			],
			category: 'image',
		},
	}

	// Call upon umi's `uploadJson` function to upload our metadata to Arweave via Irys.
		*/
	console.log('Uploading Metadata...')
	const metadataUri = await umi.uploader.uploadJson(metadata).catch((err) => {
		throw new Error(err)
	})

	//
	// ** Creating the NFT **
	//

	// We generate a signer for the NFT
	//const asset = generateSigner(umi)

	console.log('Updating NFT...')

	/*
	const tx = await create(umi, {
		asset,
		name: 'Armando NFT',
		uri: metadataUri,
	}).sendAndConfirm(umi)*/

	//const address = "Cm7ATiDeJYHmMxePkhei97miMgWkPuDPJYAXKM2NRPnN";
	const collectionAddress = "8AbQVR7qVsSbMTCWoAkADqwGBg2UGHEwnngqav69HS1t"
	
	const collection = await fetchCollection(
	  umi,
	  UMIPublicKey(collectionAddress),
	);

	const asset = await fetchAsset(umi, UMIPublicKey(address));
	console.log('asset.name',asset.name)
	//console.log('asset',asset)

	const tx = await update(umi, {
	  asset,
	  collection,
	  name: asset.name,
	  uri: metadataUri,
	}).sendAndConfirm(umi);
	//console.log('tx',tx)
	
	let explorerLink = getExplorerLink("address", asset.publicKey, "devnet");
	console.log(`Asset updated with new metadata URI: ${explorerLink}`);
	
	console.log("✅ Finished successfully!");

	// Finally we can deserialize the signature that we can check on chain.
	//const signature = base58.deserialize(tx.signature)[0]
	/*
	// Log out the signature and the links to the transaction and the NFT.
	console.log('\nNFT Created')
	console.log('View Transaction on Solana Explorer')
	console.log(`https://explorer.solana.com/tx/${signature}?cluster=devnet`)
	console.log('\n')
	console.log('View NFT on Metaplex Explorer')
	console.log(`https://core.metaplex.com/explorer/${asset.publicKey}?env=devnet`)
	const reponseURL = `https://core.metaplex.com/explorer/${asset.publicKey}?env=devnet`;
	*/
	return explorerLink
}

//createNft()
