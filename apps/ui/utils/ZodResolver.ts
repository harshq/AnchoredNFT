import { z, ZodType } from "zod";
import type { Resolver } from "react-hook-form";

export const zodResolver =
  <TSchema extends ZodType<any, any, any>>(
    schema: TSchema
  ): Resolver<z.infer<TSchema>> =>
  async (values) => {
    const result = await schema.safeParseAsync(values);

    if (result.success) {
      return {
        values: result.data,
        errors: {},
      };
    }

    const errors = result.error.issues.reduce(
      (allErrors, issue) => {
        const path = issue.path.join(".");
        allErrors[path] = {
          type: issue.code,
          message: issue.message,
        };
        return allErrors;
      },
      {} as Record<string, any>
    );

    return {
      values: {},
      errors,
    };
  };
