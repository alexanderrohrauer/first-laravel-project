<?php
/**
 * Created by deepgen.ai.
 * User: Alexander Rohrauer
 * Date: 20.09.26
 * Time: 14:32
 */

namespace App\Http\Requests\Files;

use Illuminate\Foundation\Http\FormRequest;

class FileUploadRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            "path" => "required",
            "file" => "required|mimes:jpg,png,jpeg,gif|max:4096"
        ];
    }

    public function authorize(): bool
    {
        return true;
    }
}
