import { Request, Response } from 'express';

export class IndexController {
    public getAction(req: Request, res: Response): void {
        // Handle GET request
        res.send('GET action executed by armando2');
    }

    public postAction(req: Request, res: Response): void {
        // Handle POST request
        res.send('POST action executed');
    }
}