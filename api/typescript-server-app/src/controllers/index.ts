import { Request, Response } from 'express';
import { createNft } from "./create-nft";
import { updateNft } from "./update-nft";
import { fetchNft } from "./fetch-nft";
import { fetchNftCollection } from "./fetch-collection";
import { fetchNftCollectionAssets } from './fetch-collection-assets';

export class IndexController {
    public async createNFT(req: Request, res: Response): Promise<any> {
        try {
            // Extract metadata from the request body
            const metadata = req.body;

            // Pass the metadata to the createNft function
            const response = await createNft(metadata);

            // Send the response back to the client
            res.send(response);
        } catch (error) {
            console.error('Error creating NFT:', error);
            res.status(500).send({ error: 'Failed to create NFT' });
        }
    }

    public async updateNFT(req: Request, res: Response): Promise<any> {
        // Handle GET request
        try {
            const metadata = req.body;
            const query = typeof req.query.address === 'string' ? req.query.address : 'defaultSearchValue';
            const response = await updateNft(query, metadata);
            //const responseData = response.;
            res.send(response);
        } catch (error) {
            console.error('Error updating NFT:', error);
            res.status(500).send({ error: 'Failed to update NFT' });
        }
    }

    public async fetchNFT(req: Request, res: Response): Promise<any> {
        // Handle GET request
        const query = typeof req.query.address === 'string' ? req.query.address : 'defaultSearchValue';
        const response = await fetchNft(query);
        //const responseData = response.;
        res.send(response);
    }

    public async fetchNftCollection(req: Request, res: Response): Promise<any> {
        // Handle GET request
        const query = typeof req.query.address === 'string' ? req.query.address : 'defaultSearchValue';
        const response = await fetchNftCollection(query);
        //const responseData = response.;
        res.send(response);
    }

    public async fetchNftCollectionAssets(req: Request, res: Response): Promise<any> {
        // Handle GET request
        const query = typeof req.query.address === 'string' ? req.query.address : 'defaultSearchValue';
        const response = await fetchNftCollectionAssets(query);
        //const responseData = response.;
        res.send(response);
    }


    public postAction(req: Request, res: Response): void {
        // Handle POST request
        res.send('POST action executed');
    }
}