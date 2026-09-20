<?php

/**
 * Created by deepgen.ai.
 * User: Alexander Rohrauer
 * Date: 20.09.26
 * Time: 14:31
 */

namespace App\Http\Controllers\Files;

use App\Http\Controllers\Controller;
use App\Http\Requests\Files\FileUploadRequest;
use Inertia\Inertia;
use Symfony\Component\CssSelector\Exception\InternalErrorException;

class FilesController extends Controller
{
    public function uploadFile(FileUploadRequest $request)
    {
        $path = $request->file('file')->storePublicly($request->input('path'), 's3');

        if(!$path) {
            return back()->with('error', 'Error uploading file.');
        }

        return Inertia::flash(['path' => $path])->back();
    }
}
