import { Request, Response } from 'express';
import { createNft } from "./create-nft";

export class IndexController {
    public async getAction(req: Request, res: Response): Promise<any> {
        // Handle GET request
        const response = await createNft();
        res.send(response);
    }

    public postAction(req: Request, res: Response): void {
        // Handle POST request
        res.send('POST action executed');
    }
}