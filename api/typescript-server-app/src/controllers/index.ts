import { Request, Response } from 'express';
import { createNft } from "./create-nft";
import { updateNft } from "./update-nft";

export class IndexController {
    public async getAction(req: Request, res: Response): Promise<any> {
        // Handle GET request
        const response = await createNft();
        //const responseData = response.;
        res.send(response);
    }

    public async updateNFT(req: Request, res: Response): Promise<any> {
        // Handle GET request
        const response = await updateNft();
        //const responseData = response.;
        res.send(response);
    }

    public postAction(req: Request, res: Response): void {
        // Handle POST request
        res.send('POST action executed');
    }
}