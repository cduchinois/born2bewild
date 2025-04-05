import { mplCore, fetchAsset, fetchCollection, fetchAssetsByCollection } from '@metaplex-foundation/mpl-core';
import { publicKey as UMIPublicKey } from '@metaplex-foundation/umi';
import { createUmi } from '@metaplex-foundation/umi-bundle-defaults';
import { getExplorerLink } from "@solana-developers/helpers";

export const fetchNftCollectionAssets = async (address: string): Promise<any> => {
    const umi = createUmi('https://api.devnet.solana.com').use(mplCore());
    const assets = await fetchAssetsByCollection(umi, UMIPublicKey("8AbQVR7qVsSbMTCWoAkADqwGBg2UGHEwnngqav69HS1t"));
    //console.log('Asset:', assets);
    const uris = assets.map(asset => asset.uri);
    //console.log('URIs:', uris);
    return uris;
};
