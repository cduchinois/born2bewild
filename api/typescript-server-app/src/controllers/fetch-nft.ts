import { mplCore, fetchAsset } from '@metaplex-foundation/mpl-core';
import { publicKey as UMIPublicKey } from '@metaplex-foundation/umi';
import { createUmi } from '@metaplex-foundation/umi-bundle-defaults';
import { getExplorerLink } from "@solana-developers/helpers";

export const fetchNft = async (address: string): Promise<any> => {
    const umi = createUmi('https://api.devnet.solana.com').use(mplCore());

    //console.log('Fetching NFT Data...');
    //const address = "Cm7ATiDeJYHmMxePkhei97miMgWkPuDPJYAXKM2NRPnN";
    const asset = await fetchAsset(umi, UMIPublicKey(address));
    //console.log('Asset:', asset);
    //console.log('Asset Name:', asset.name);
    const uri = asset.uri;
    //console.log('Fetching metadata from URI:', uri);

    try {
        const response = await fetch(uri);
        if (!response.ok) {
            throw new Error(`Failed to fetch metadata: ${response.statusText}`);
        }
        const metadata = await response.json();
        console.log('Metadata:', metadata);

        return metadata;
    } catch (error) {
        console.error('Error fetching metadata:', error);
        throw error;
    }
};
