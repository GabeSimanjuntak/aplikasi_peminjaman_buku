<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;

class UserRegisteredMail extends Mailable
{
    use Queueable, SerializesModels;

    public $nama;

    public function __construct($nama)
    {
        $this->nama = $nama;
    }

    public function envelope()
    {
        return new Envelope(
            subject: 'Registrasi Akun Berhasil',
        );
    }

    public function content()
    {
        return new Content(
            markdown: 'emails.user_registered',
        );
    }
}
