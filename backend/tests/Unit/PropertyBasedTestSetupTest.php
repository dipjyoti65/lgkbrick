<?php

namespace Tests\Unit;

use Eris\Generator;
use Eris\TestTrait;
use PHPUnit\Framework\TestCase;

class PropertyBasedTestSetupTest extends TestCase
{
    use TestTrait;

    /**
     * Test that Eris property-based testing is properly configured
     * **Feature: lgk-brick-management, Property Setup: Eris Configuration Test**
     */
    public function testErisSetupWorking()
    {
        $this->forAll(
            Generator\int()
        )->then(function ($number) {
            // Simple property: adding zero to any number should return the same number
            $this->assertEquals($number, $number + 0);
        });
    }

    /**
     * Test that string concatenation property works
     * **Feature: lgk-brick-management, Property Setup: String Concatenation Test**
     */
    public function testStringConcatenationProperty()
    {
        $this->forAll(
            Generator\string(),
            Generator\string()
        )->then(function ($str1, $str2) {
            // Property: length of concatenated strings equals sum of individual lengths
            $concatenated = $str1 . $str2;
            $this->assertEquals(strlen($str1) + strlen($str2), strlen($concatenated));
        });
    }
}